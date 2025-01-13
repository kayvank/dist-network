{-# LANGUAGE TemplateHaskell #-}

module Local.Master where

import Control.Distributed.Process
  ( Process
  , expect
  , getSelfNode
  , say
  , send
  , spawn
  , terminate
  )
import Control.Distributed.Process.Internal.Closure.TH (mkStaticClosure)
import Control.Distributed.Process.Internal.Primitives (getSelfPid)
import DistribUtils (distribMain)
import Message (Message (..))
import PingServer (pingServer, pingServer__static, __remoteTable)
import Text.Printf (printf)

master :: Process ()
master = do
  nodeid <- getSelfNode
  say $ printf "spawning on %s" (show nodeid)
  pid <- spawn nodeid $(mkStaticClosure 'pingServer)
  mypid <- getSelfPid
  say $ printf "sending ping to %s" (show mypid)
  send pid (Ping mypid)
  Message.Pong _ <- expect
  say "pong"
  terminate

runMaster :: IO ()
runMaster = distribMain (const master) __remoteTable
