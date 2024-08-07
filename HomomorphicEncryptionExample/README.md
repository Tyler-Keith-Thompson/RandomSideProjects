So [Apple recently announced](https://www.swift.org/blog/announcing-swift-homomorphic-encryption/) a new [swift-homomorphic-encryption](https://github.com/apple/swift-homomorphic-encryption) library that looks really cool! They even included a [live caller id example project](https://github.com/apple/live-caller-id-lookup-example) that does showcase how it works. 

Unfortunately, if you're anything like me, this example is rather hard to parse through because there's a LOT going on with Oblivious HTTP and PrivacyPass and then everything is using Protobuf...it makes it hard to just understand how the homomorphic encryption part works!

This is a *very* simple project, it started with `vapor new HomomorphicEncryptionExample` and then I deleted a little boilerplate and got a single test that showcases how all this would work from both the client and server side (make sure to check out the test code to understand what's happening)

Notionally, I love the idea that utilizing homomorphic encryption you could request something from a server without the server ever being exposed to what it is you asked for. I mean the cool thing here is "I want to look up an item in a database" with the attached "and the server won't know which item, but will still return it" idea. So, how does one go about that?

First, I found [a really helpful introduction](https://educatedguesswork.org/posts/pir/) to the PIR (Private Informaton Retrieval) process. I loved this overview of how everything works and the blog is littered with other very insightful information! So this explains the concept of an indexed request, a client has to know:
- How many items are in the database
- How big items are
- What index (note, this means everybody has to have the same sorting!) it wants (the ith element)

As cool as that is, the standard use-case doesn't have a client knowing what index it wants, it usually has an ID it'll look up. So now we're into scarier reading material. I found a [whitepaper on KPIR](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=70d2a37d5af527dfc345691e2f978f6e46dc4efe#:~:text=Private%20information%20retrieval%20(PIR)%20schemes,data%20stored%20in%20the%20database.) which was illuminating, but not exactly easy reading. It builds off all the same concepts but the important takeaway here is that it's similar to the indexed PIR except that it uses a keyword, which can tie to a database identifier.

In `AppTests` you'll find basically what the client code would look like. How does it create an encrypted query, how does it parse the response, that kind of thing. 

In `TodoController` you'll see the server side implementation to process that request and give a valid response.

> IMPORTANT! None of this code is production ready. I really hope nobody would ever copy code from a GitHub repo called "RandomSideProjects" into production and somehow expect everything would go well...this is just an example project to showcase how all this comes together.