port module Sub.Listener.Ports exposing (error, success)


port success : (Json -> msg) -> Sub msg


port error : (String -> msg) -> Sub msg


type alias Json =
    String
