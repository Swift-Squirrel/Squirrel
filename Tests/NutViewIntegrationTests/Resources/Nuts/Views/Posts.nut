<!-- Posts.html -->

\Layout("Default")

\Title("Posts")

<div class="row mb-3">
    <div class="col">
        <h1>Posts</h1>
    </div>
</div>

\for post in posts {
<div class="row">
<div class="col">
    <article class="row border rounded mb-3 p-1" style="max-height: 400px">
        <div class="col-6 mx-auto col-md-3 align-self-center">
            <img class="rounded img-fluid" src="Images/Logos/squirrel.svg">
        </div>
        <div class="col-12 col-md-9">
            <div class="row">
                <div class="col">
                    <h1><a class="text-dark" href="/posts/\(post.id)">\(post.title)</a></h1>
                </div>
            </div>
            <div class="row">
                <div class="col text-truncate">
                    \(post.brief)
                </div>
            </div>
            <div class="row text-muted">
                <div class="col">
                    \(post.likes) <span class="ml-1 mr-2 text-success oi oi-thumb-up"></span>
                    \(post.comments.count) <span class="ml-1 mr-2 oi oi-chat"></span>
                    \(post.dislikes) <span class="ml-1 mr-2 text-danger oi oi-thumb-down"></span>
                </div>
                <div class="col text-right  align-self-end">
                    \Date(post.created)
                </div>
            </div>
        </div>
    </article>
    </div>
</div>
\}
