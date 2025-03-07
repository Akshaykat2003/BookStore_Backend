# frozen_string_literal: true

require 'rails_helper'
RSpec.configure do |config|
  # Specify the root folder where OpenAPI JSON/YAML files are generated
  config.openapi_root = Rails.root.join('swagger').to_s  # Updated method

  # Define OpenAPI documents with global metadata
  config.openapi_specs = {   # Updated method
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'  # Updated for local development
            }
          }
        }
      ]
    }
  }

  # Output format of the OpenAPI file
  config.openapi_format = :yaml  # Updated method
end
