An implementation of the [Nanobox Custom Provider](https://docs.nanobox.io/providers/create/) spec for DigitalOcean.

## Development

### Local Server
`bundle exec puma -e development`

### Update Catalog

### Local Evars
A DigitalOcean Access Token is required to update the catalog files.
`nanobox evar add ACCESS_TOKEN=your_digital_ocean_access_token`
Update catalog config files.
`bundle exec rake catalog:update`

### Console
`bundle exec irb -I. -r app.rb`
