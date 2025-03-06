require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let!(:existing_user) { User.create!(full_name: 'Akshay Katoch', email: 'akshay@example.com', password: 'Test@123', mobile_number: '9876543210') }
  let!(:otp) { PasswordService.generate_otp }

  before do
    PasswordService::OTP_STORAGE[existing_user.email] = { otp: otp, otp_expiry: Time.now + 5 * 60 }
  end

  path '/api/v1/signup' do
    post 'User Registration' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              full_name: { type: :string },
              email: { type: :string },
              password: { type: :string, format: :password },
              mobile_number: { type: :string }
            },
            required: ['full_name', 'email', 'password', 'mobile_number']
          }
        }
      }

      response '201', 'User registered successfully' do
        let(:user) { { user: { full_name: 'New User', email: 'newuser@example.com', password: 'Test@123', mobile_number: '9876543211' } } }
        run_test!
      end

      response '422', 'Email already taken' do
        let(:user) { { user: { full_name: 'Akshay Katoch', email: existing_user.email, password: 'Test@123', mobile_number: '9876543210' } } }
        run_test!
      end
    end
  end

  path '/api/v1/login' do
    post 'User Login' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string, format: :password }
        },
        required: ['email', 'password']
      }

      response '200', 'Login successful' do
        let(:credentials) { { email: existing_user.email, password: 'Test@123' } }
        run_test!
      end

      response '401', 'Invalid email or password' do
        let(:credentials) { { email: existing_user.email, password: 'WrongPass' } }
        run_test!
      end
    end
  end

  
  path '/api/v1/forgot_password' do
    post 'Forgot Password' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :email, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string }
        },
        required: ['email']
      }

      response '200', 'OTP sent successfully' do
        let(:email) { { email: existing_user.email } }
        run_test!
      end

      response '422', 'User not found' do
        let(:email) { { email: 'nonexistent@example.com' } }
        run_test!
      end
    end
  end

  path '/api/v1/reset_password' do
    post 'Reset Password' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :reset_data, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          otp: { type: :string },
          new_password: { type: :string, format: :password }
        },
        required: ['email', 'otp', 'new_password']
      }

      response '200', 'Password reset successful' do
        let(:reset_data) { { email: existing_user.email, otp: otp, new_password: 'NewPass@123' } }
        run_test!
      end

      response '422', 'Invalid OTP' do
        let(:reset_data) { { email: existing_user.email, otp: 'wrong_otp', new_password: 'NewPass@123' } }
        run_test!
      end

      response '422', 'User not found' do
        let(:reset_data) { { email: 'nonexistent@example.com', otp: '123456', new_password: 'NewPass@123' } }
        run_test!
      end
    end
  end
end
