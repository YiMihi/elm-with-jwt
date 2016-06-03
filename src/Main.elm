module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
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

type alias Model = String
    
init : (Model, Cmd Msg)
init =
    ("", Cmd.none)
    
-- Messages

type Msg 
    = GetQuote
    | FetchSuccess String
    | FetchError Http.Error    
               
-- View

view : Model -> Html Msg
view model =
    div [ class "jumbotron row text-center" ] [
        h2 [] [ text "Chuck Norris Quoter" ]
        , button [ class "btn btn-primary", onClick GetQuote ] [ text "Get a Quote" ]
        , blockquote [ ] [ text model ]
    ]
    
url : String
url =    
    "http://localhost:3001/api/random-quote"
    
fetchTask : Platform.Task Http.Error String
fetchTask =
    Http.getString url
    
fetchCmd : Cmd Msg
fetchCmd =
    Task.perform FetchError FetchSuccess fetchTask     
    
-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            (model, fetchCmd)
        FetchSuccess quote ->
            (quote, Cmd.none)
        FetchError _ ->
            (model, Cmd.none)       
    
-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.none