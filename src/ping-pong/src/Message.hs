module Message
  ( Message (..)
  , PID
  ) where

import Control.Distributed.Process (ProcessId)
import Data.Binary (Binary)
import Data.Dynamic (Typeable)
import GHC.Generics (Generic)

type PID = ProcessId
data Message
  = Ping PID
  | Pong PID
  deriving (Generic, Typeable)

instance Binary Message
