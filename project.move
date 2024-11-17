module BloggingPlatform::Blog {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use aptos_std::vector;
    use std::string::String;

    /// Error codes
    const E_POST_NOT_FOUND: u64 = 1;
    const E_NOT_POST_OWNER: u64 = 2;

    /// Struct representing a blog post
    struct BlogPost has store, key {
        author: address,
        content: String,
        timestamp: u64,
        likes: u64,
    }

    /// Resource to store all posts by an author
    struct UserPosts has key {
        posts: vector<BlogPost>,
    }

    /// Create a new blog post
    public fun create_post(author: &signer, content: String) acquires UserPosts {
        let author_addr = signer::address_of(author);

        // Initialize UserPosts if it doesn't exist
        if (!exists<UserPosts>(author_addr)) {
            move_to(author, UserPosts { posts: vector::empty() });
        };

        // Add post to user's posts
        let user_posts = borrow_global_mut<UserPosts>(author_addr);
        let post = BlogPost {
            author: author_addr,
            content: content,
            timestamp: timestamp::now_seconds(),
            likes: 0,
        };
        vector::push_back(&mut user_posts.posts, post);
    }

    /// Like a blog post
    public fun like_post(_user: &signer, author: address, post_index: u64) acquires UserPosts {
        let user_posts = borrow_global_mut<UserPosts>(author);
        assert!(post_index < vector::length(&user_posts.posts), E_POST_NOT_FOUND);

        let post = vector::borrow_mut(&mut user_posts.posts, post_index);
        post.likes = post.likes + 1;
    }
}