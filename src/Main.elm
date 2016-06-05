module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import String

import Http
import Http.Decorators
import Task exposing (Task)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

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
    * initialize model with empty values
-}

type alias Model =
    { username : String
    , password : String
    , token : String
    , quote : String
    , protectedQuote : String
    }
    
init : (Model, Cmd Msg)
init =
    (Model "" "" "" "" "", Cmd.none)
    
{-
    MESSAGES
    * Msg type
-}

type Msg 
    = GetQuote
    | FetchQuoteSuccess String
    | HttpError Http.Error
    | SetUsername String
    | SetPassword String
    | ClickRegisterUser
    | ClickLogIn
    | GetTokenSuccess String
    | GetProtectedQuote
    | FetchProtectedQuoteSuccess String
    | LogOut
    
{-
    UPDATE
    * API routes
    * GET and POST
    * Encode request body 
    * Decode responses
    * Update case
-}

-- API request URLs
    
api : String
api =
     "http://localhost:3001/"    
    
randomQuoteUrl : String
randomQuoteUrl =    
    api ++ "api/random-quote"
    
registerUrl : String
registerUrl =
    api ++ "users"  
    
loginUrl : String
loginUrl =
    api ++ "sessions/create"   
    
protectedQuoteUrl : String
protectedQuoteUrl = 
    api ++ "api/protected/random-quote"      

-- GET a random quote (unauthenticated)
    
fetchRandomQuote : Platform.Task Http.Error String
fetchRandomQuote =
    Http.getString randomQuoteUrl
    
fetchRandomQuoteCmd : Cmd Msg
fetchRandomQuoteCmd =
    Task.perform HttpError FetchQuoteSuccess fetchRandomQuote     

-- Encode user to construct POST request body (for Register and Log In)
    
userEncoder : Model -> Encode.Value
userEncoder model = 
    Encode.object 
        [("username", Encode.string model.username)
        , ("password", Encode.string model.password)]          

-- POST register request and decode token response
    
registerUser : Model -> Task Http.Error (String)
registerUser model =
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = registerUrl
    , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder
    
registerUserCmd : Model -> Cmd Msg
registerUserCmd model =
    Task.perform HttpError GetTokenSuccess <| registerUser model

-- POST log in request and decode token response
    
login : Model -> Task Http.Error (String)
login model =
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = loginUrl
    , body = Http.string <| Encode.encode 0 <| userEncoder model
    }
    |> Http.send Http.defaultSettings
    |> Http.fromJson tokenDecoder
    
loginCmd : Model -> Cmd Msg
loginCmd model =
    Task.perform HttpError GetTokenSuccess <| login model 
    
-- Decode POST response to get token
    
tokenDecoder : Decoder String
tokenDecoder =
    "id_token" := Decode.string         
    
-- GET request for random protected quote (authenticated)
    
fetchProtectedQuote : Model -> Task Http.Error String
fetchProtectedQuote model = 
    { verb = "GET"
    , headers = [ ("Authorization", "Bearer " ++ model.token) ]
    , url = protectedQuoteUrl
    , body = Http.empty
    }
    |> Http.send Http.defaultSettings  
    |> Http.Decorators.interpretStatus -- decorates Http.send result so error type is Http.Error instead of RawError
    |> Task.map responseText    
    
fetchProtectedQuoteCmd : Model -> Cmd Msg
fetchProtectedQuoteCmd model = 
    Task.perform HttpError FetchProtectedQuoteSuccess <| fetchProtectedQuote model 
    
-- Extract GET plain text response to get protected quote    
    
responseText : Http.Response -> String
responseText response = 
    case response.value of 
        Http.Text t ->
            t 
        _ ->
            ""           

-- Greeting for a logged in user
    
greeting : Model -> String
greeting model =
    "Hello, " ++ model.username ++ "!"

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
        SetUsername username ->
            ({ model | username = username }, Cmd.none)
        SetPassword password ->
            ({ model | password = password }, Cmd.none)
        ClickRegisterUser ->
            (model, registerUserCmd model)
        ClickLogIn ->
            (model, loginCmd model)    
        GetTokenSuccess newToken ->
            ({ model | token = newToken } |> Debug.log "got new token", Cmd.none) 
        GetProtectedQuote ->
            (model, fetchProtectedQuoteCmd model)      
        FetchProtectedQuoteSuccess newPQuote ->
            ({ model | protectedQuote = newPQuote } |> Debug.log "set protected quote", Cmd.none)  
        LogOut ->
            ({ model | username = "", password = "", protectedQuote = "", token = "" } |> Debug.log "log out", Cmd.none)   
                       
{-
    VIEW
    * Hide sections of view depending on authenticaton state of model
    * Get a quote
    * Log In or Register
    * Get a protected quote
-}

view : Model -> Html Msg
view model =
    let 
        -- Logic to hide sections of view when authentication state changes
        hideIfLoggedIn = 
            if String.length model.token > 0 then "hidden" else ""
        hideIfLoggedOut = 
            if String.isEmpty model.token then "hidden" else ""  
        hideIfNoQuote = 
            if String.isEmpty model.quote then "hidden" else ""     
        hideIfNoProtectedQuote = 
            if String.isEmpty model.protectedQuote then "hidden" else ""     
    in
        div [ class "container" ] [
            h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
            , p [ class "text-center" ] [
                button [ class "btn btn-success", onClick GetQuote ] [ text "Grab a quote!" ]
            ]
            -- Blockquote with quote: only show if a quote is present in model
            , blockquote [ class hideIfNoQuote ] [ 
                p [] [text model.quote] 
            ]
            , div [ class "jumbotron text-left" ] [
                -- Login / Register form: only show if not logged in
                div [ id "form", class hideIfLoggedIn ] [
                    h2 [ class "text-center" ] [ text "Log In or Register" ]
                    , p [ class "help-block" ] [ text "If you already have an account, please Log In. Otherwise, enter your desired username and password and Register." ]
                    , div [ class "form-group row" ] [
                        div [ class "col-md-offset-4 col-md-4" ] [
                            label [ for "username" ] [ text "Username:" ]
                            , input [ id "username", type' "text", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                        ]    
                    ]
                    , div [ class "form-group row" ] [
                        div [ class "col-md-offset-4 col-md-4" ] [
                            label [ for "password" ] [ text "Password:" ]
                            , input [ id "password", type' "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                        ]    
                    ]
                    , div [ class "text-center" ] [
                        button [ class "btn btn-primary", onClick ClickLogIn ] [ text "Log In" ]
                        , button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
                    ] 
                ]
                -- Greeting and Log Out button: only show if logged in
                , div [ class hideIfLoggedOut ][
                    h3 [ class "text-center" ] [ text (greeting model) ]
                    , p [ class "text-center" ] [ text "Welcome back! You can now access protected quotes." ]
                    , p [ class "text-center" ] [
                        button [ class "btn btn-danger", onClick LogOut ] [ text "Log Out" ]
                    ]   
                ]  
            -- Protected Quotes: only show if logged in  
            ], div [ class hideIfLoggedOut ] [
                h2 [ class "text-center" ] [ text "Protected Chuck Norris Quotes" ]
                , p [ class "text-center" ] [
                    button [ class "btn btn-danger", onClick GetProtectedQuote ] [ text "Grab a protected quote!" ]
                ]
                -- Blockquote with protected quote: only show if a protectedQuote is present in model
                , blockquote [ class hideIfNoProtectedQuote ] [ 
                    p [] [text model.protectedQuote] 
                ]
            ]
        ]