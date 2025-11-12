# Movie & TV Show API Recommendations

This document contains recommended APIs for fetching movies, TV shows, and their characters for the AI Character Chat App.

## Recommended APIs

### 1. TMDb (The Movie Database) API - **RECOMMENDED FOR MOVIES**

**Overview:**
- Most comprehensive movie and TV show database
- Completely **FREE** for non-commercial use
- Excellent documentation and community support
- Extensive cast and character data

**Key Features:**
- Movie and TV show information
- Cast and crew details with profile images
- Character names and roles
- High-quality posters and images
- Multilingual support
- Ratings and reviews

**Endpoints:**
- `/movie/{movie_id}` - Get movie details
- `/movie/{movie_id}/credits` - Get cast and crew
- `/tv/{tv_id}` - Get TV show details
- `/tv/{tv_id}/credits` - Get TV show cast
- `/tv/{tv_id}/aggregate_credits` - Get all season credits
- `/search/movie` - Search movies
- `/search/tv` - Search TV shows
- `/search/person` - Search actors/characters

**Documentation:**
- Main: https://www.themoviedb.org/documentation/api
- Developer Portal: https://developer.themoviedb.org/reference/intro/getting-started

**Getting Started:**
1. Sign up at https://www.themoviedb.org/signup
2. Get your free API key from account settings
3. Base URL: `https://api.themoviedb.org/3`

**Example Request:**
```
GET https://api.themoviedb.org/3/movie/550/credits?api_key=YOUR_API_KEY
```

**Example Response Structure:**
```json
{
  "cast": [
    {
      "id": 819,
      "name": "Edward Norton",
      "character": "The Narrator",
      "profile_path": "/eIkFHNlfretLS1spAcIoihKUS62.jpg"
    }
  ]
}
```

---

### 2. TVMaze API - **RECOMMENDED FOR TV SHOWS**

**Overview:**
- Specialized in TV shows
- Completely **FREE** with no API key required
- Excellent character-level data
- Fast and clean REST API

**Key Features:**
- Comprehensive TV show information
- Detailed episode lists and schedules
- Character information with images
- Cast and guest appearances
- Character importance ranking
- Episode-level cast credits

**Endpoints:**
- `/search/shows?q={query}` - Search TV shows
- `/shows/{id}` - Get show details
- `/shows/{id}/cast` - Get show cast
- `/shows/{id}/episodes` - Get all episodes
- `/people/{id}` - Get person details
- `/people/{id}/castcredits` - Get all cast credits

**Documentation:**
- https://www.tvmaze.com/api

**Getting Started:**
- No API key needed!
- Base URL: `https://api.tvmaze.com`

**Example Request:**
```
GET https://api.tvmaze.com/shows/82/cast
```

**Example Response Structure:**
```json
[
  {
    "person": {
      "id": 1,
      "name": "Bryan Cranston",
      "image": {
        "medium": "https://static.tvmaze.com/uploads/images/medium_portrait/0/2.jpg"
      }
    },
    "character": {
      "id": 1,
      "name": "Walter White",
      "image": {
        "medium": "https://static.tvmaze.com/uploads/images/medium_portrait/0/1.jpg"
      }
    }
  }
]
```

---

### 3. OMDb API - **ALTERNATIVE**

**Overview:**
- Simple and straightforward
- Good for basic movie data
- Affordable pricing

**Pricing:**
- Free tier: 1,000 calls/day
- Paid: Small monthly donation removes limit

**Documentation:**
- https://www.omdbapi.com/

---

## Implementation Recommendations

### Hybrid Approach (Recommended)
Use **TMDb** for movies and **TVMaze** for TV shows to get the best character data from both platforms.

### Integration Steps

1. **Add HTTP Package**
   ```yaml
   dependencies:
     http: ^1.1.0
     # or
     dio: ^5.4.0  # for more advanced features
   ```

2. **Create API Service Classes**
   - `lib/services/tmdb_service.dart` for TMDb integration
   - `lib/services/tvmaze_service.dart` for TVMaze integration

3. **Data Models**
   - Update `MoviesSeries` model to handle API data
   - Add `Character` model for detailed character info
   - Add `Actor` model for actor/person data

4. **Features to Implement**
   - Search functionality
   - Popular/Trending content
   - Detailed character bios
   - Actor photos and info
   - Show/Movie ratings
   - Trailers and videos (TMDb provides these)

### Rate Limiting & Best Practices

**TMDb:**
- 40 requests per 10 seconds
- Cache responses when possible

**TVMaze:**
- 20 requests per 10 seconds
- No authentication needed
- Very generous free tier

**Caching Strategy:**
- Use `cached_network_image` package (already added)
- Cache API responses locally
- Implement refresh intervals

---

## Next Steps

1. Choose your preferred API(s)
2. Sign up and get API keys (TMDb only)
3. Create service classes for API integration
4. Update models to match API response structure
5. Implement search and browse functionality
6. Add error handling and loading states
7. Test with real data

---

## Additional Resources

- **TMDb Flutter Package:** https://pub.dev/packages/tmdb_api
- **HTTP Package:** https://pub.dev/packages/http
- **Dio Package:** https://pub.dev/packages/dio

---

*Note: All APIs mentioned respect copyright and licensing. Always check terms of service for your specific use case.*
