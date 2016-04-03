class UserMailer < ActionMailer::Base
  

  default from: 'mailer.vardhanagencies@gmail.com'
  

  def welcome_email(user)
  	@user = user
    mail(to: @user.email, subject: 'Welcome to Vardhan Agencies, Sirsi')
  end

  def password_reset(user)
  	@user = user
    mail(to: @user.email, subject: 'Vardhan Agencies, Sirsi Your password has been reseted')
  end	

end