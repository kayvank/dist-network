{-# LANGUAGE TemplateHaskell #-}

module PingServer where

import Control.Distributed.Process (Process, expect, getSelfPid, say, send)
import Control.Distributed.Process.Closure (remotable)
import Message (Message (..))
import Text.Printf (printf)

{-|
If there are no messages of the right type, expect will block until one arrives.
-}
pingServer :: Process ()
pingServer = do
  Ping from <- expect
  say $ printf "ping received from %s" (show from)
  mypid <- getSelfPid
  send from (Pong mypid)

remotable ['pingServer]
