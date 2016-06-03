import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Task

main : Program Never
main = 
    Html.program 
        { init = init 
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
    
-- Model

type alias Model =
    { quote : String }
    
init : (Model, Cmd Msg)
init =
    (Model "", Cmd.none)
    
-- Update

type Msg = GetQuote

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            (model, Cmd.none)
            
-- View

view : Model -> Html Msg
view model =
    div []
        [ button [ onClick GetQuote ] [ text "Get a Quote" ]
        , div [] [ text (model.quote) ]
        ]
        
-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.none