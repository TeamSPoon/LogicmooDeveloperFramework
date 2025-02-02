
:- use_module(library(sockets)).
	
server :-
	server(1985,
	       [type(text), encoding('UTF-16LE')],
	       "水").
		 %"foo").

server(Port, OpenStreamParameters, String) :-
	socket_server_open(Port, Socket),
	socket_server_accept(Socket, _Client, Stream, OpenStreamParameters),
	format(Stream, 'message("~s").~n', [String]),
	format('~N--- Written to stream: message(~s)~n', [String]),
	flush_output(Stream),
	close(Stream),
	socket_server_close(Socket),
	!.
