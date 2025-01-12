{-# LANGUAGE TemplateHaskell #-}

module DistribUtils (distribMain) where

import Control.Distributed.Process (NodeId, Process, RemoteTable)
import Control.Distributed.Process.Backend.SimpleLocalnet
  ( initializeBackend
  , startMaster
  , startSlave
  )
import Control.Distributed.Process.Closure ()
import Control.Distributed.Process.Node (initRemoteTable)

import Network.Socket ()
import System.Environment (getArgs)

import Language.Haskell.TH ()

distribMain :: ([NodeId] -> Process ()) -> (RemoteTable -> RemoteTable) -> IO ()
distribMain master frtable = do
  args <- getArgs
  let rtable = frtable initRemoteTable

  case args of
    [] -> do
      backend <- initializeBackend defaultHost defaultPort rtable
      startMaster backend master
    ["master"] -> do
      backend <- initializeBackend defaultHost defaultPort rtable
      startMaster backend master
    ["master", port] -> do
      backend <- initializeBackend defaultHost port rtable
      startMaster backend master
    ["slave"] -> do
      backend <- initializeBackend defaultHost defaultPort rtable
      startSlave backend
    ["slave", port] -> do
      backend <- initializeBackend defaultHost port rtable
      startSlave backend
    ["slave", host, port] -> do
      backend <- initializeBackend host port rtable
      startSlave backend

defaultHost :: String
defaultHost = "localhost"
defaultPort :: String
defaultPort = "44444"
