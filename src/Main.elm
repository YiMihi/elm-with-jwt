import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Http
import Json.Decode exposing (list, string)
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

type Msg 
    = GetQuote
    | FetchSucceed String
    | FetchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
    case action of
        GetQuote ->
            (model, getRandomQuote)
            
        FetchSucceed newQuote ->
            (Model newQuote, Cmd.none)
            
        FetchFail _ ->
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
    
-- HTTP

getRandomQuote : Platform.Task Http.Error String
getRandomQuote = 
    Http.getString "http://localhost:3001/api/random-quote"
            