require('@kbrw/node_erlastic').server(function (term, from, current_amount, done) {
    if (term == "hello") return done("reply", "Hello World!");
    if (term == "what") return done("reply", "What what ?");
    if (term == "kbrw") return done("reply", current_amount, current_amount - 2);
    if (term[0] == "kbrw") return done("noreply", term[1]);
    throw new Error("unexpected request")
});