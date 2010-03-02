% Simple Bridge
% Copyright (c) 2008-2010 Rusty Klophaus
% See MIT-LICENSE for licensing information.

-module (mochiweb_response_bridge).
-behaviour (simple_bridge_response).
-include_lib ("simple_bridge.hrl").
-export ([build_response/2]).

build_response({Req, DocRoot}, Res) ->	
    % Some values...
    Code = Res#response.statuscode, 
    case Res#response.data of
        {data, Body} ->

            % Assemble headers...
            Headers = lists:flatten([
                [{X#header.name, X#header.value} || X <- Res#response.headers],
                [create_cookie_header(X) || X <- Res#response.cookies]
            ]),		

            % Send the mochiweb response...
            Req:respond({Code, Headers, Body});
        {file, Path} ->
            Req:serve_file(tl(Path), DocRoot)
    end.

create_cookie_header(Cookie) ->
    SecondsToLive = Cookie#cookie.minutes_to_live * 60,
    Name = Cookie#cookie.name,
    Value = Cookie#cookie.value,
    Path = Cookie#cookie.path,
    mochiweb_cookies:cookie(Name, Value, [{path, Path}, {max_age, SecondsToLive}]).
