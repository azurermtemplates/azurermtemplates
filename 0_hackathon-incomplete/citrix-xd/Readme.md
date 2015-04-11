# ARM Templates for Citrix XenApp and XenDesktop

Citrix is embracing Azure as a first class cloud platform to transform our existing on-prem based products into a service offering in Azure for virtual desktops and app delivery.
The current model is based on Service manager. While it works, cloud services have performance and capacity bottlenecks that prevent us from scaling our solution. So we are excited about ARM.

In the Hackathon, we've crafted templates for standing up the Citrix XenDesktop infrastructure consisting of 

1. Citrix Desktop Delivery Controller
2. Large numbers of Citrix VDAs (the actual desktop virtualization software that runs on the virtual desktops)
3. Citrix Storefront (a portal like "marketplace" for end-users to access applications)

We have also extensively used DSC within the JSON files. We've learned a lot today about ARM, especially the DSC integration part (special thanks to Sergey Vorobev and Travis Plunk for their help).

We plan to work closely with ARM going forward. 