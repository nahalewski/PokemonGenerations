# This file assumes the user is ABSOLUTELY not using Ruby in a rbenv folder!
$LOAD_PATH.delete_if { |path| path.start_with?('/opt/homebrew') }

