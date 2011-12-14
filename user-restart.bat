echo.
echo This file waits two minutes in between server restarts so the site is never fully down.
echo.

net stop vae_survey_31_1
net start vae_survey_31_1
ping 1.1.1.1 -n 2 -w 60000
net stop vae_survey_31_2
net start vae_survey_31_2
ping 1.1.1.1 -n 2 -w 60000
net stop vae_survey_31_3
net start vae_survey_31_3
ping 1.1.1.1 -n 2 -w 60000
net stop vae_survey_31_4
net start vae_survey_31_4


