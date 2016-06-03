module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Task exposing (Task)

main : Program Never
main = 
    Html.program 
        { init = init 
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
    
-- Model

type alias Quote = String
    
init : (Quote, Cmd Msg)
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

view : Quote -> Html Msg
view quote =
    div [ class "container row text-center" ] [
        h2 [] [ text "Chuck Norris Quotes" ]
        , button [ class "btn btn-primary", onClick GetQuote ] [ text "Grab a quote!" ]
        , blockquote [ class "text-left" ] [ 
            p [] [text quote] 
        ]
    ]
    
-- Update

update : Msg -> Quote -> (Quote, Cmd Msg)
update action quote =
    case action of
        GetQuote ->
            (quote, fetchRandomQuoteCmd)
        FetchQuoteSuccess quote ->
            (quote, Cmd.none)
        FetchError _ ->
            (quote, Cmd.none)       
    
-- Subscriptions

subscriptions : Quote -> Sub Msg
subscriptions model = 
    Sub.none