net stop vae_survey_31_1
net stop vae_survey_31_2
net stop vae_survey_31_3
net stop vae_survey_31_4

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set date=%%c%%a%%b)

rename log\production.log production_%date%.log

net start vae_survey_31_1
net start vae_survey_31_2
net start vae_survey_31_3
net start vae_survey_31_4

