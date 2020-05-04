fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>

### google_api_key_list_allowed_bundle_ids
```
    google_api_key_list_allowed_bundle_ids(
      project_number: "some:project-id",
      api_key_id: "fd1d4e87-0ba5-4e2e-bacd-54d96b70befd",
      type: 'ios',
      username: ENV['GOOGLE_USERNAME'],
      password: ENV['GOOGLE_PASSWORD'],
    )
```
```
    google_api_key_list_allowed_bundle_ids(
      project_number: "some:project-id",
      api_key_id: "fd1d4e87-0ba5-4e2e-bacd-54d96b70befd",
      type: 'android',
      username: ENV['GOOGLE_USERNAME'],
      password: ENV['GOOGLE_PASSWORD'],
    )
```

### google_api_key_add_allowed_bundle_ids
```
    google_api_key_add_allowed_bundle_ids(
      project_number: "some:project-id",
      api_key_id: "fd1d4e87-0ba5-4e2e-bacd-54d96b70befd",
      type: 'ios',
      bundle_id: 'com.example.test',
      username: ENV['GOOGLE_USERNAME'],
      password: ENV['GOOGLE_PASSWORD'],
    )
    google_api_key_add_allowed_bundle_ids(
      project_number: "some:project-id",
      api_key_id: "fd1d4e87-0ba5-4e2e-bacd-54d96b70befd",
      type: 'android',
      bundle_id: 'com.example.test',
      fingerprint: '2a:ae:6c:35:c9:4f:cf:b4:15:db:e9:5f:40:8b:9c:e9:1e:e8:46:ed',
      username: ENV['GOOGLE_USERNAME'],
      password: ENV['GOOGLE_PASSWORD'],
    )
```

### firebase_get_server_key

```
    firebase_get_server_key(
      project_number: "project-name-or-number",
      username: ENV['GOOGLE_USERNAME'],
      password: ENV['GOOGLE_PASSWORD'],
    )
```

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
