# Timetracker
The TimeTracker is a simple tray application written initially in Delphi Seattle, that pops up a dialog every 15 minutes to ask what you are currently working on.  It timestamps every entry and saves them to an SDF text file using the pipe character ("|") as a delimiter.

A ComboBox is used for text entry and it keeps the last 5 entries in it's list, always displaying the last entered item by default when the dialog is presented.  Clicking Ignore does not add a time entry regardless of whether you typed something in the combobox.  Clicking Ok adds a new time entry.  If the text is the same as the previous entry, it is simply ignored.

Right clicking the tray icon shows a local menu that allows the user to open the dialog (in the event they are starting a new task or switching back to a previous one), open the log file, or open the folder in which log files are stored.  The user can also exit the application.  When the application is launched it attempts to read the last 5 log entries to re-populate the MRU list.

The application automatically creates a new text file if the timestamp for the current message is for a new day, so there is no need to close and re-launch it every day.
