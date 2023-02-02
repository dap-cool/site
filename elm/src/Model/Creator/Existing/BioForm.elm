module Model.Creator.Existing.BioForm exposing (BioForm(..))


type BioForm
    = Empty
    | Valid String
    | Invalid String
