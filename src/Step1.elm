import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)

main : Program Never
main = 
    Html.beginnerProgram 
        { model = model
        , view = view
        , update = update
        }
    
{-
    MODEL
-}    

type alias Model = String

model : Model
model = 
    "Hello world!"
    
{-
    UPDATE
-}    

type Msg = SayHello

update : Msg -> Model -> Model
update msg model =
    case msg of
        SayHello ->
            model ++ " Hello Elm!"
            
{-
    VIEW
-}    

view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SayHello ] [ text "Say Hello" ]
        , p [] [ text (toString model) ]
        ]