# Build Output folder

Sometimes you just want to make sure the MOF can be built locally, without trying to converge it, for a fast feedback.
This is useful to validate that the process works, for instance making sure that the Config Data is not missing pieces, such as all required parameters to a resource are set (and not $null).

Another reason is when you have a working configuration and you want to push it to a remote system. You can compile the MOF, and push it to a remote machine (i.e. using my DscBuildHelpers\Push-DscConfiguration).