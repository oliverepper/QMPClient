This repository represents my understanding of how to implement a LineFramer for Network Framework.

I've watched the session [Advances in Networking, Part 2](https://developer.apple.com/videos/play/wwdc2019/713/) and this article [Intro to Network.framework Servers](https://www.alwaysrightinstitute.com/network-framework/).  Both gave me my understanding which is not sufficient, obviously.

The problem:

The app connects to a UNIX socket in `/tmp/my.sock` where I provide some messages via the `demo_server.sh` script:

```bash
socat UNIX-LISTEN:/tmp/my.sock SYSTEM:'{
printf "first line\nsecond line\nthird line\n" |
(
dd bs=14 count=1 2>/dev/null
dd bs=14 count=1 2>/dev/null
dd bs=8 count=1 2>/dev/null
)
}'
```

So the framer receives "first line\nsec" and successfully emits "first line" to the app.  The `handleInput` function then returns 0.

From the documentation:

> Returning 0 indicates that the handler should be invoked once any data is available.

So I think the second chuck of 14 bytes delivered by dd sends "ond line\nthird".  But the closure passed to `parseInput` only every sees the previous rest "ond".

Idea:

I could buffer the "ond" myself and concat it to "ond line\n" once that arrives.  But from the documentation I was expecting to be called with a buffer containing: "second line\nthird".


I totally see that all of this is possible to be forced into oom by a malicious attacker, but the framer runs in user space, right?  So I was expecting the framer to buffer and update the buffer for me.  Reading the article above I might not be alone with that expectation, right?
