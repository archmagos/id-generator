# IdGenerator

A Ruby gem for generating secure 8-character IDs based on IP addresses and context, with daily ID support and color assignment for poster IDs. For forums and discussion platforms where you want temporary user identification without storing personal data.

## Features

- Generate **unique IDs** from IP addresses using SHA256 hashing with server-side salt protection
- Daily **ID rotation** for enhanced privacy
- Consistent hexadecimal **color assignment** for each ID
- No database required - IDs computed on-demand

## How It Works

1. **IP + Salt + Context** → SHA256 hash → First 8 characters = **Anonymous ID**
2. **Daily IDs**: Include current date as context for automatic rotation  
3. **Colours**: Convert first 4 characters of ID to HSL color (70% saturation, 50% lightness)
4. **Security**: Server-side salt prevents rainbow table attacks on IP addresses

## Usage

### Configuration

Set the required environment variable:

```bash
export ID_GENERATOR_SALT=kestrel_knave
```

### Basic ID Generation

```ruby
require 'id_generator'

# Generate context-specific ID (context arg can be left blank or included as an additional hasing variable)
IdGenerator.generate('192.168.1.1', 'thread_123')
# => "a4f2b8e1"

# Generate daily ID (same ID all day, new ID tomorrow)  
IdGenerator.generate_daily('192.168.1.1')
# => "7c9d3a2f"

# Get consistent color for any ID
IdGenerator.get_color('a4f2b8e1')
# => "#D9A326"
```

## Server Integration

An example of how you might use this feature in a real-world scenario:

```ruby
require 'sinatra'
require 'id_generator'

posts = []

post '/posts' do
  poster_id = IdGenerator.generate_daily(request.ip)
  poster_color = IdGenerator.get_color(poster_id)

  posts << {
    content: params[:content],
    poster_id: poster_id,
    poster_color: poster_color
  }
  
  redirect '/'
end

# At point of rendering the posts in the frontend, the colour is thus available for styling

```
