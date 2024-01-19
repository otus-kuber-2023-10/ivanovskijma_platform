# ivanovskijma_platform
ivanovskijma Platform repository

## Kubernetes templating

1. Развернут кластер в облаке и ingress-nginx с помощью terraform. 
2. С помощью helmfile установлены chart-museum, cert-manager, harbor.
3. Создан helm чарт фронтенда приложения hipster-shop.
4. Развернуты микросервисы paymentservice и shippingservice с помощью kubecfg.
6. Развернут микросервис recommendationservice с помощью kustomize.
