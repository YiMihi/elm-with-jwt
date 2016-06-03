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
    
-- Model

type alias Model = String

model : Model
model = 
    "Some Quote"
    
-- Update

type Msg = GetQuote

update : Msg -> Model -> Model
update msg model =
    case msg of
        GetQuote ->
            model
            
-- View

view : Model -> Html Msg
view model =
    div []
        [ button [ onClick GetQuote ] [ text "Get a Quote" ]
        , div [] [ text (toString model) ]
        ]