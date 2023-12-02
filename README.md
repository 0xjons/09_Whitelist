# 09_Whitelist Contract

## Descripción
El contrato `Whitelist` es un sistema de control de acceso basado en blockchain que permite la gestión eficiente de una lista de direcciones autorizadas (whitelist). Este contrato se ha desarrollado con Solidity y está diseñado para funcionar en la red Ethereum y redes compatibles con EVM como Polygon.

## Características
- **Gestión de Whitelist**: Añade o elimina direcciones de la whitelist.
- **Control de Acceso**: Restringe el acceso a funciones específicas a solo aquellas direcciones en la whitelist.
- **Banear Direcciones**: Permite al propietario del contrato banear direcciones específicas.
- **Requerimiento de Saldo Mínimo de Tokens**: Los usuarios deben tener un saldo mínimo de un token ERC20 específico para añadirse a la whitelist.
- **Retiro de Fondos**: Función para que el propietario retire los fondos acumulados en el contrato.

## Funciones Principales
- `addToWhitelist(address[] calldata users)`: Añade múltiples direcciones a la whitelist.
- `removeFromWhitelist(address user)`: Elimina una dirección de la whitelist.
- `banFromWhitelist(address user)`: Banea una dirección.
- `toggleWhitelistStatus()`: Activa o desactiva la whitelist.
- `selfAddToWhitelist()`: Permite a un usuario añadirse a la whitelist pagando una tarifa.
- `selfRemoveFromWhitelis()`: Permite a un usuario eliminarse de la whitelist.
- `setMinimumBalance(uint256 _newMinimumBalance)`: Establece el saldo mínimo de tokens requerido.
- `isUserBanned(address user)`: Verifica si una dirección está baneada.
- `isUserWhitelisted(address user)`: Verifica si una dirección está en la whitelist.
- `withdraw(address payable recipient)`: Retira los fondos del contrato.

## Tecnología
- Solidity ^0.8.22
- OpenZeppelin Contracts (Ownable, ReentrancyGuard, IERC20)

## Cómo Utilizar
1. **Despliegue**: Despliega el contrato en la red Ethereum o en cualquier red compatible con EVM.
2. **Gestión de la Whitelist**: Utiliza las funciones proporcionadas para gestionar las direcciones en la whitelist.

## Seguridad
Este contrato incluye características de seguridad como `ReentrancyGuard` para prevenir ataques de reentrancia y utiliza el patrón `Ownable` para el control de acceso administrativo.

---

Desarrollado con ❤️ por 0xjons.
