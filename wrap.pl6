use v6;

while True {
	say "Starting";
	shell('./RUN');
	CATCH { default { put .^name, ': ', .Str } };
}

