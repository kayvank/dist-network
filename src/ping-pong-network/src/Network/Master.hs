{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Network.Master where

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
import Control.Distributed.Process.Internal.Closure.TH (mkStaticClosure)
import Control.Distributed.Process.Internal.Primitives (getSelfPid)
import Control.Monad (forM, forM_)
import DistribUtils (distribMain)
import Message (Message (..))
import PingServer (pingServer, pingServer__static)
import PingServer qualified as Main
import Text.Printf (printf)

master :: [NodeId] -> Process ()
master peers = do
  ps <- forM peers $ \nid -> do
    say $ printf "spawning on %s" (show nid)
    spawn nid $(mkStaticClosure 'pingServer)
  mypid <- getSelfPid
  forM_ ps $ \pid -> do
    say $ printf "ping %s" (show pid)
    send pid (Ping mypid)
  waitForPongs ps
  say "All pongs successfully received"
  terminate

waitForPongs :: [ProcessId] -> Process ()
waitForPongs [] = pure ()
waitForPongs ps =
  expect >>= \case
    Pong p -> waitForPongs (filter (/= p) ps)
    _ -> say "MASTER received ping" >> terminate

runMaster :: IO ()
runMaster = distribMain master Main.__remoteTable
