#!/usr/bin/env -S swipl -q

% Simple web chat in SWI Prolog
% Cypyright:  	  Pelle Hjek 2020
% Free software:  AGPL 3+

:- module(chat, [post_form//0]).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_client)).
:- use_module(library(http/html_head)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).

:- use_module(library(persistency)).

serve(Port) :-
  http_server(http_dispatch, [port(Port)]).

:- persistent message(time, text).
:- db_attach('chat_messages.pl', []).

:- http_handler(root(.),
		chat_handler(Method),
		[method(Method), methods([get,post])]).

post_form -->
    html(
	form([action(.), method(post)],
	     [input([name(text)]),
	      input([type(submit),value(send)])])).

messages_list(Ms) -->
    html(ul(\messages_list_(Ms))).

messages_list_([]) -->
    html([]).

messages_list_([M|T]) -->
    html([li(M), \messages_list_(T)]).

autorefresh() -->
    html(meta(["http-equiv"="refresh", content("30")])).

chat_handler(get, _Request):-
    findall(M, (message(Time,Text), M=Time-Text), Pairs),
    sort(1, @>=, Pairs, Sorted_pairs),
    pairs_values(Sorted_pairs, Sorted),
    reply_html_page(
    [title(chat),\autorefresh],
    [\post_form, \messages_list(Sorted)]).

chat_handler(post, Request):-
    ( member(referer(Referer), Request) -> Then=Referer; Then=root(.)),
    http_parameters(Request,
		    [text(Text, [])]),
    get_time(Now),
    assert_message(Now,Text),
    http_redirect(see_other, Then, Request).

:- serve(9090), writeln("serving chat on port 9090").
