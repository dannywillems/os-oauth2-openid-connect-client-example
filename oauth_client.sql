-- README:
-- Do not remove the field with a `-- DEFAULT` suffix.
-- That's the default tables/fields needed by Eliom-base-app

CREATE TABLE users ( -- DEFAULT
       userid bigserial primary key, -- DEFAULT
       firstname text NOT NULL,
       lastname text NOT NULL,
       password text,
       avatar text
);

CREATE EXTENSION citext; --DEFAULT
-- You may remove the above line if you use the type TEXT for emails instead of CITEXT

CREATE TABLE emails ( -- DEFAULT
       email citext primary key, -- DEFAULT
       userid bigint NOT NULL references users(userid), -- DEFAULT
       validated boolean NOT NULL DEFAULT(false)
);

CREATE TABLE activation ( -- DEFAULT
       activationkey text primary key, -- DEFAULT
       userid bigint NOT NULL references users(userid), -- DEFAULT
       creationdate timestamptz NOT NULL default now()
);

CREATE TABLE groups ( -- DEFAULT
       groupid bigserial primary key, -- DEFAULT
       name text NOT NULL, -- DEFAULT
       description text -- DEFAULT
);

CREATE TABLE user_groups ( -- DEFAULT
       userid bigint NOT NULL references users(userid), -- DEFAULT
       groupid bigint NOT NULL references groups(groupid) -- DEFAULT
);

CREATE TABLE preregister (
       email citext NOT NULL
);

-- Table for OAuth2.0 server. An Eliom application can be a OAuth2.0 server.
-- Its client can be OAuth2.0 client which can be an Eliom application, but not
-- always.
---- Table to represent and register client
CREATE TABLE oauth2_server_client (
       id bigserial primary key,
       application_name text not NULL,
       description text not NULL,
       logo text not NULL,
       redirect_uri text not NULL,
       client_id text not NULL,
       client_secret text not NULL
);

---- Table to represent access token. There are not primary keys.
CREATE TABLE oauth2_server_token (
       id_client bigint not NULL references oauth2_server_client(id), -- the id from oauth2_server_client representing the client
       userid bigint not NULL references users(userid), -- the id of the user associated with the token
       token text not NULL,
       token_type text not NULL,
       scope text NOT NULL -- fields the client has access to
);

-- Table for OAuth2.0 client. An Eliom application can be a OAuth2.0 client of a
-- OAuth2.0 server which can be also an Eliom application, but not always.
CREATE TABLE oauth2_client_credentials (
       -- Is it very useful ? Remove it implies an application can be a OAuth
       -- client of a OAuth server only one time. For the moment, algorithms works
       -- with the server_id which are the name and so id is useless.
       id bigserial primary key,
       server_id text not NULL, -- to remember which OAuth2.0 server is. The server name can be used.
       server_authorization_url text not NULL,
       server_token_url text not NULL,
       server_data_url text not NULL,
       client_id text not NULL,
       client_secret text not NULL
);

-- Need a table to remember tokens. We don't need to know which user of the
-- OAuth2 server authorizes.
-- - client_credentials_id: foreign key to the id in oauth2_client_credentials
-- table. We need it to remember from which server comes the token.
-- - token: the token.
-- - token_type: the token type. For example «bearer».
-- - scope: the scope asked when requesting the token.
--
-- We don't remember the data on the client because these data can change on
-- the server.
--)
CREATE TABLE oauth2_client_grant_users (
       client_credentials_id bigint not NULL references oauth2_client_credentials(id),
       token text not NULL,
       token_type text not NULL,
       scope text not NULL
)
