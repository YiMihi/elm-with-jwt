# Outline

- Introduction
    - About Elm
    - About JSON Web Tokens
- Installing Elm
    - How to install Elm globally
    - Dependencies / build config
- Hello World Elm app 
    - Create a basic main view
- How to call an API with Elm
    - Call unauthenticated route from [nodejs-jwt-authentication-sample](https://github.com/auth0-blog/nodejs-jwt-authentication-sample) GET `/api/random-quote`
- How to authenticate with JWT
    - Sign up form view and POST users `/users`
    - Create login view and POST to create session token `/sessions/create`
    - Save token to localStorage and verify authentication
    - Make authenticated API requests GET `/api/protected/random-quote`
    - Log out (remove token)
- ...etc
- Conclusion

## Considerations / Research / TODOs

- Gulp? Webpack?
- Foundation or Bootstrap?
- Elm: How to make http requests? Management of promises?
- Elm: How to handle routing?