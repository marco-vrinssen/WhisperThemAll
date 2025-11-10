# Whisper Them All

World of Warcraft Retail addon that enables sending batch whispers to multiple players with saved message templates.

## Features

- **Batch Whispers**: Send the same message to multiple players at once
- **Saved Player List**: Maintain a persistent list of player names across sessions
- **Message Templates**: Save and reuse predefined whisper messages
- **Easy Management**: Simple UI for managing your player list and messages
- **Quick Commands**: Fast slash commands for immediate batch sending

## Usage

### Commands

- `/wta` or `/whisperthemall` - Open the player list management window
- `/wta MESSAGE` - Send MESSAGE to all players in your saved list

### Managing Your Player List

1. Type `/wta` to open the player list window
2. Enter character names, one per line
3. The list is automatically saved as you type
4. Close the window when done

### Setting Up Message Templates

1. Open the player list window with `/wta`
2. Click **Configure Message** button
3. Enter your predefined whisper message (up to 3 lines, 260 characters)
4. Click **Save** to store the message

### Sending Whispers

**Option 1: Using Predefined Message**
1. Open the player list window with `/wta`
2. Click **Send Whispers** button
3. The chat box will open with your saved message pre-filled
4. Press Enter to confirm and send to all players

**Option 2: Using Command Line**
- Type `/wta Your custom message here` to immediately send to all players

## Examples

```
/wta                              # Opens management window
/wta Hey, want to run some M+?   # Sends message to all players in list
```

## Data Storage

The addon saves the following data:
- **Player Names**: Your list of whisper recipients
- **Message Template**: Your predefined message

All data is stored in `WhisperThemAllDB` and persists across sessions.

## Compatibility

- **Interface Version**: 11.2.0 (The War Within)
- **Game Version**: World of Warcraft Retail

## Notes

- Player names are trimmed of whitespace automatically
- Empty lines in the player list are ignored
- Messages are limited to WoW's whisper character limits
- The addon provides feedback when sending whispers

## License

Free to use and modify.
