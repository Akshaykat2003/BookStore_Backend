require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let(:user) { create(:user, password: "Test@123", password_confirmation: "Test@123") }
  let(:valid_headers) { { "Authorization" => "Bearer #{JwtService.encode({ user_id: user.id })}" } }

  describe "POST /api/v1/signup" do
    let(:valid_user_params) do
      {
        full_name: "Akshay Katoch",
        email: "akshay@example.com",
        password: "Test@123",
        mobile_number: "9876543210"
      }
    end

    it "registers a user successfully" do
      post "/api/v1/signup", params: { user: valid_user_params }, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include("message" => "User registered successfully")
    end

    it "fails when email is already taken" do
      create(:user, email: "akshay@example.com")
      post "/api/v1/signup", params: { user: valid_user_params }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
    end
  end

  describe "POST /api/v1/login" do
    let(:login_params) { { email: user.email, password: "Test@123" } }

    it "logs in successfully" do
      post "/api/v1/login", params: login_params, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("message" => "Login successful", "token" => anything)
    end

    it "fails with incorrect password" do
      post "/api/v1/login", params: { email: user.email, password: "WrongPass" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to include("errors" => "Invalid email or password") # Fixed key from "error" to "errors"
    end
  end

  describe "POST /api/v1/forgot_password" do
    it "sends a password reset email successfully" do
      allow(PasswordService).to receive(:forgot_password).with(user.email).and_return({ success: true, message: "Reset email sent" })

      post "/api/v1/forgot_password", params: { email: user.email }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("message" => "Reset email sent")
    end

    it "fails when email is not found" do
      allow(PasswordService).to receive(:forgot_password).with("nonexistent@example.com").and_return({ success: false, error: "Email not found" })

      post "/api/v1/forgot_password", params: { email: "nonexistent@example.com" }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to include("errors" => "Email not found") # Fixed key from "error" to "errors"
    end
  end

  describe "POST /api/v1/reset_password" do
    let(:reset_params) { { email: user.email, otp: "123456", new_password: "NewPass@123" } }

    it "resets the password successfully" do
      allow(PasswordService).to receive(:reset_password).with(user.email, "123456", "NewPass@123").and_return({ success: true, message: "Password reset successful" })

      post "/api/v1/reset_password", params: reset_params, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("message" => "Password reset successful")
    end

    it "fails when OTP is invalid" do
      allow(PasswordService).to receive(:reset_password).with(user.email, "wrongOTP", "NewPass@123").and_return({ success: false, error: "Invalid OTP" })

      post "/api/v1/reset_password", params: reset_params.merge(otp: "wrongOTP"), as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to include("errors" => "Invalid OTP") # Fixed key
    end
  end
end
