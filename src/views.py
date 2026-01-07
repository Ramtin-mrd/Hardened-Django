from django.http import HttpResponse
def health_check(request):
    return HttpResponse("<h1 style='color: green;'>🛡️ Secure Django System: ACTIVE</h1><p>Infrastructure is Hardened & Read-Only.</p>")
