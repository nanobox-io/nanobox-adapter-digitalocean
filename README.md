An implementation of the [Nanobox Custom Provider](https://docs.nanobox.io/providers/create/) spec for DigitalOcean.

## Development

### Local Server
`bundle exec puma -e development`

### Update Catalog

### Local Evars
A DigitalOcean Access Token is required to retrieve the catalog.
`nanobox evar add ACCESS_TOKEN=your_digital_ocean_access_token`

### Console
`bundle exec irb -I. -r app.rb`
