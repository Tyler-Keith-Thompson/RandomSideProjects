# EmailValidation

This Swift package provides a way to validate than an email is valid. Please note, this library does *not* guarantee that a provided email address can receive mail, it only guarantees that a given string is an RFC compliant email address.

# Why?
Because [regular](https://michaellong.medium.com/please-do-not-use-regex-to-validate-email-addresses-e90f14898c18) [expressions](https://davidcel.is/articles/stop-validating-email-addresses-with-regex/) are a [bad choice](https://www.loqate.com/resources/blog/3-reasons-why-you-should-stop-using-regex-email-validation/) for [email validation](https://stackoverflow.com/questions/48055431/can-it-cause-harm-to-validate-email-addresses-with-a-regex). I'm hoping that a Swift library purpose made for this might give people an easier out than trying to write a regex. Plus, it makes for a great little side-project.