module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Creator.Existing.Authorized exposing (Authorized)
import Model.Creator.Existing.HandleFormStatus exposing (HandleFormStatus)


type Existing
    = Top
    | HandleForm HandleFormStatus
    | Authorized Authorized
