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
        , subscriptions = \_ -> Sub.none
        }
    
{- 
    MODEL
    * Model type 
    * Initialize model with empty values
    * Initialize with a random quote
-}

type alias Model =
    { quote : String
    }
    
init : (Model, Cmd Msg)
init =
    ( Model ""
    , fetchRandomQuoteCmd
    )
    
{-
    MESSAGES
    * Msg type
-}

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error
    
{-
    UPDATE
    * API routes
    * GET
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"   

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote     

-- Update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GetQuote ->
            (model, fetchRandomQuoteCmd)
        FetchQuoteSuccess newQuote ->
            ({ model | quote = newQuote }, Cmd.none)
        HttpError _ ->
            (model, Cmd.none)  
                       
{-
    VIEW
    * Get a quote
-}

view : Model -> Html Msg
view model =
    div [ class "container" ] [
        h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
        , p [ class "text-center" ] [
            button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
        ]
        -- Blockquote with quote
        , blockquote [] [ 
            p [] [text model.quote] 
        ]
    ]