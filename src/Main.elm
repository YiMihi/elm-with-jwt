module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
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
    ("Waiting for a quote...", Cmd.none)
    
-- Messages

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | FetchError Http.Error
    
api : String
api =
     "http://localhost:3001/api/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "random-quote"
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform FetchError FetchQuoteSuccess fetchRandomQuote       
               
-- View

view : Model -> Html Msg
view model =
    div [ class "container row text-center" ] [
        h2 [] [ text "Chuck Norris Quotes" ]
        , button [ class "btn btn-primary", onClick GetQuote ] [ text "Grab a quote!" ]
        , blockquote [ class "text-left" ] [ 
            p [] [text model] 
        ]
    ]
    
-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            (model, fetchRandomQuoteCmd)
        FetchQuoteSuccess quote ->
            (quote, Cmd.none)
        FetchError _ ->
            (model, Cmd.none)       
    
-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.none