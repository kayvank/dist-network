{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Remote.Master where

import Control.Distributed.Process
  ( NodeId
  , Process
  , ProcessId
  , expect
  , say
  , send
  , spawn
  , terminate
  )
import Control.Distributed.Process.Closure (remotable)
import Control.Distributed.Process.Internal.Closure.TH (mkStaticClosure)
import Control.Distributed.Process.Internal.Primitives (getSelfPid)
import Control.Monad (forM, forM_)
import DistribUtils (distribMain)
import Message (Message (..))

-- import PingServer (pingServer, pingServer__static, __remoteTable)
import Text.Printf (printf)

pingServer :: Process ()
pingServer = do
  say "in pingserver"
  Ping from <- expect
  say $ printf "ping received from %s" (show from)
  mypid <- getSelfPid
  send from (Pong mypid)

remotable ['pingServer]
master :: [NodeId] -> Process ()
master peers = do
  say $ printf "number of peers: %d" (length peers)
  ps <- forM peers $ \nid -> do
    say $ printf "spawning on %s" (show nid)
    spawn nid $(mkStaticClosure 'pingServer)
  mypid <- getSelfPid
  say $ printf "mypid %s" (show mypid)
  forM_ ps $ \pid -> do
    say $ printf "ping %s" (show pid)
    send pid (Ping mypid)
  waitForPongs ps
  say "All pongs successfully received"
  terminate

waitForPongs :: [ProcessId] -> Process ()
waitForPongs [] = pure ()
waitForPongs ps =
  say (printf "processids : %s" (show ps))
    >> expect
    >>= \case
      Pong p -> waitForPongs (filter (/= p) ps)
      _ -> say "MASTER received ping" >> terminate

runMaster :: IO ()
runMaster = do
  putStrLn "in runMaster"
  distribMain master Remote.Master.__remoteTable
