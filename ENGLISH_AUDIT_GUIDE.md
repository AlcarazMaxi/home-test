# Language Content Audit Guide — Finding and Fixing Non-English Content

## Overview

This guide shows how to find and fix non-English content in the codebase using automated tools and manual review.

## Tools Required

- **ripgrep (rg)**: Fast text search
- **cspell**: Spell checker
- **VS Code** or **Cursor**: For batch find/replace

## Step 1: Automated Search with ripgrep

### 1.1) Search for Non-English Characters

**Windows (CMD)**:
```cmd
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡" > audit-spanish-chars.txt
```

**Windows (PowerShell)**:
```powershell
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡" | Out-File -Encoding UTF8 audit-spanish-chars.txt
```

**macOS/Linux**:
```bash
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡" > audit-spanish-chars.txt
```

### 1.2) Search for Common Non-English Words

**Windows (CMD)**:
```cmd
rg -i "\b(hola|mundo|gracias|por favor|buenos días|buenas tardes|adiós|hasta luego|de nada|lo siento|perdón|disculpe|nombre|contraseña|usuario|correo|teléfono|dirección|ciudad|país|estado|código postal|fecha|hora|día|mes|año|semana|lunes|martes|miércoles|jueves|viernes|sábado|domingo|enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\b" > audit-spanish-words.txt
```

**macOS/Linux**:
```bash
rg -i "\b(hola|mundo|gracias|por favor|buenos días|buenas tardes|adiós|hasta luego|de nada|lo siento|perdón|disculpe|nombre|contraseña|usuario|correo|teléfono|dirección|ciudad|país|estado|código postal|fecha|hora|día|mes|año|semana|lunes|martes|miércoles|jueves|viernes|sábado|domingo|enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\b" > audit-spanish-words.txt
```

### 1.3) Search in Specific File Types

**TypeScript/JavaScript**:
```bash
rg -i "á|é|í|ó|ú|ñ" --type ts --type js
```

**Java**:
```bash
rg -i "á|é|í|ó|ú|ñ" --type java
```

**Gherkin Features**:
```bash
rg -i "á|é|í|ó|ú|ñ" --glob "*.feature"
```

**Documentation**:
```bash
rg -i "á|é|í|ó|ú|ñ" --type md
```

## Step 2: Review Audit Results

### 2.1) Categorize Findings

Review `audit-spanish-chars.txt` and `audit-spanish-words.txt`:

| Category | Priority | Examples | Action |
|----------|----------|----------|--------|
| **Code identifiers** | HIGH | `nombreUsuario`, `contraseña` | Rename to `userName`, `password` |
| **Test names** | HIGH | `test('Usuario puede iniciar sesión')` | Translate to `test('User can log in')` |
| **Comments** | MEDIUM | `// Verificar que el usuario existe` | Translate to `// Verify that the user exists` |
| **Log messages** | MEDIUM | `console.log('Error al iniciar sesión')` | Translate to `console.log('Login error')` |
| **Documentation** | LOW | README in Spanish | Translate to English |
| **Test data** | LOW | `{ name: 'Juan' }` | Change to `{ name: 'John' }` |

### 2.2) Prioritization Strategy

1. **Phase 1**: Code identifiers and test names (breaks compilation if skipped)
2. **Phase 2**: Comments and log messages (affects readability)
3. **Phase 3**: Documentation and test data (cosmetic)

## Step 3: Common Spanish → English Mappings

### 3.1) Variable Names

| Spanish | English |
|---------|---------|
| `nombreUsuario` | `userName` |
| `contraseña` | `password` |
| `correoElectronico` | `email` |
| `fechaNacimiento` | `dateOfBirth` |
| `telefono` | `phoneNumber` |
| `direccion` | `address` |
| `ciudad` | `city` |
| `pais` | `country` |
| `codigoPostal` | `zipCode` |
| `botonEnviar` | `submitButton` |
| `campoTexto` | `textField` |
| `listaDesplegable` | `dropdown` |
| `casilla` | `checkbox` |
| `radioBoton` | `radioButton` |

### 3.2) Function Names

| Spanish | English |
|---------|---------|
| `obtenerUsuario` | `getUser` |
| `crearUsuario` | `createUser` |
| `actualizarUsuario` | `updateUser` |
| `eliminarUsuario` | `deleteUser` |
| `iniciarSesion` | `login` |
| `cerrarSesion` | `logout` |
| `verificarCredenciales` | `verifyCredentials` |
| `enviarFormulario` | `submitForm` |
| `llenarCampo` | `fillField` |
| `hacerClic` | `click` |

### 3.3) Test Names

| Spanish | English |
|---------|---------|
| `Usuario puede iniciar sesión` | `User can log in` |
| `Usuario puede cerrar sesión` | `User can log out` |
| `Formulario de registro funciona correctamente` | `Registration form works correctly` |
| `Validación de campos obligatorios` | `Required field validation` |
| `Mensaje de error se muestra` | `Error message is displayed` |

### 3.4) Comments

| Spanish | English |
|---------|---------|
| `// Verificar que el usuario existe` | `// Verify that the user exists` |
| `// Inicializar la página de inicio de sesión` | `// Initialize the login page` |
| `// Enviar el formulario` | `// Submit the form` |
| `// Esperar a que la página cargue` | `// Wait for the page to load` |
| `// Validar el resultado` | `// Validate the result` |

## Step 4: Programmatic Refactoring

### 4.1) TypeScript/JavaScript (jscodeshift)

**Create codemod** (`codemods/spanish-to-english.js`):

```javascript
// Codemod to rename Spanish identifiers to English
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  
  // Define mappings
  const renamings = {
    'nombreUsuario': 'userName',
    'contraseña': 'password',
    'correoElectronico': 'email',
    'botonEnviar': 'submitButton',
    'iniciarSesion': 'login',
    'cerrarSesion': 'logout'
  };
  
  // Rename all identifiers
  Object.keys(renamings).forEach(oldName => {
    const newName = renamings[oldName];
    
    root.find(j.Identifier, { name: oldName })
      .forEach(path => {
        path.node.name = newName;
      });
  });
  
  return root.toSource();
};
```

**Run codemod**:
```bash
npx jscodeshift -t codemods/spanish-to-english.js ui-tests/**/*.ts
```

### 4.2) Java (OpenRewrite)

**Create recipe** (`rewrite.yml`):

```yaml
---
type: specs.openrewrite.org/v1beta/recipe
name: com.example.SpanishToEnglish
displayName: Spanish to English identifier renames
description: Renames Spanish identifiers to English equivalents
recipeList:
  - org.openrewrite.java.ChangeMethodName:
      methodPattern: "com.example.* getNombreUsuario()"
      newMethodName: "getUserName"
  - org.openrewrite.java.ChangeMethodName:
      methodPattern: "com.example.* setNombreUsuario(String)"
      newMethodName: "setUserName"
  - org.openrewrite.java.ChangeFieldName:
      fieldName: "nombreUsuario"
      newFieldName: "userName"
```

**Run OpenRewrite**:
```bash
mvn rewrite:run
```

## Step 5: Manual Review with IDE

### 5.1) Find and Replace in VS Code/Cursor

1. Press `Ctrl+Shift+H` (Windows/Linux) or `Cmd+Shift+H` (macOS)
2. Enter Spanish term in "Find" field
3. Enter English term in "Replace" field
4. Use "Replace All" or review each instance

**Example**:
- Find: `nombreUsuario`
- Replace: `userName`

### 5.2) Regex Find/Replace

For more complex patterns:

**Find**: `const (\w+)Usuario = `  
**Replace**: `const $1User = `

## Step 6: Spell Check with cspell

### 6.1) Run cspell

**UI Tests**:
```bash
cd ui-tests
npm run spell
```

**API Tests**:
```bash
cd api-tests
npx cspell "src/**/*.{java,feature,md}"
```

### 6.2) Fix Spelling Errors

If cspell reports errors:

1. **Legitimate English words**: Add to `cspell.config.cjs` `words` array
2. **Typos**: Fix the spelling
3. **Spanish words**: Translate to English

**Example** (`ui-tests/cspell.config.cjs`):

```javascript
words: [
  "playwright",
  "testid",
  "localhost",
  "yourNewTerm"  // Add here
]
```

## Step 7: Validation

### 7.1) Re-run Audit

```bash
# Should return no results
rg -i "á|é|í|ó|ú|ñ|ü|¿|¡"
```

### 7.2) Run Tests

**UI Tests**:
```bash
cd ui-tests
npm test
```

**API Tests**:
```bash
cd api-tests
mvn clean test
```

### 7.3) Run Linters

**UI Tests**:
```bash
cd ui-tests
npm run lint
npm run format:check
npm run spell
```

**API Tests**:
```bash
cd api-tests
mvn checkstyle:check
mvn spotbugs:check
npx cspell "src/**/*"
```

## Step 8: Commit Changes

### 8.1) Stage Changes

```bash
git add .
```

### 8.2) Commit with English Message

```bash
git commit -m "refactor: convert all identifiers and comments to professional English

- Rename Spanish variable names to English equivalents
- Translate all test names to English
- Translate all comments to English
- Update documentation to professional English
- Add cspell configuration to enforce en-US
- All spelling checks pass

Closes #123"
```

### 8.3) Push to Remote

```bash
git push origin feature/english-refactor
```

## Common Pitfalls

### Pitfall 1: Breaking Selectors

**Problem**: Renaming `data-testid="botonEnviar"` in code but not in the app  
**Solution**: Coordinate with dev team or use a mapping layer

### Pitfall 2: False Positives

**Problem**: ripgrep finds "José" in test data  
**Solution**: Decide if test data should also be in English (recommendation: yes)

### Pitfall 3: Mixed Languages in Strings

**Problem**: `console.log('Error: usuario no encontrado')`  
**Solution**: Extract to constants or i18n files

## Best Practices

1. **Incremental refactoring**: One module/page at a time
2. **Test after each change**: Ensure no breakage
3. **Use version control**: Commit frequently
4. **Document mappings**: Keep a glossary of Spanish → English terms
5. **Automate validation**: CI should fail on Spanish content

## Appendix: ripgrep Cheat Sheet

| Command | Description |
|---------|-------------|
| `rg "pattern"` | Search for pattern |
| `rg -i "pattern"` | Case-insensitive search |
| `rg --type ts "pattern"` | Search in TypeScript files only |
| `rg --glob "*.feature" "pattern"` | Search in Gherkin files |
| `rg -l "pattern"` | List files with matches |
| `rg -c "pattern"` | Count matches per file |
| `rg -A 3 "pattern"` | Show 3 lines after match |
| `rg -B 3 "pattern"` | Show 3 lines before match |
| `rg -C 3 "pattern"` | Show 3 lines around match |

## Appendix: cspell Cheat Sheet

| Command | Description |
|---------|-------------|
| `npx cspell "**/*.ts"` | Check all TypeScript files |
| `npx cspell --no-progress "**/*"` | Check all files without progress |
| `npx cspell --show-suggestions "**/*"` | Show spelling suggestions |
| `npx cspell --words-only "**/*"` | List unknown words only |
| `npx cspell --config cspell.config.cjs` | Use custom config |

---

**Happy Refactoring!** 🔧

