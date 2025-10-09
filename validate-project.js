#!/usr/bin/env node

/**
 * Principal QA Engineer - Project Validation Script
 * Comprehensive validation for automation project delivery readiness
 */

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// ANSI color codes for output formatting
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

// Validation results tracking
const results = {
  preflight: { passed: 0, failed: 0, issues: [] },
  tests: { passed: 0, failed: 0, issues: [] },
  quality: { passed: 0, failed: 0, issues: [] },
  reports: { passed: 0, failed: 0, issues: [] }
};

// Utility functions
const log = (message, color = colors.reset) => console.log(`${color}${message}${colors.reset}`);
const check = (condition, message, category = 'preflight') => {
  if (condition) {
    log(`  ✓ ${message}`, colors.green);
    results[category].passed++;
  } else {
    log(`  ✗ ${message}`, colors.red);
    results[category].failed++;
    results[category].issues.push(message);
  }
};

const runCommand = (command, cwd = process.cwd()) => {
  try {
    return execSync(command, { cwd, encoding: 'utf8', stdio: 'pipe' });
  } catch (error) {
    return { error: error.message, stderr: error.stderr };
  }
};

// Main validation functions
async function validatePreflight() {
  log('\n🔍 PRE-FLIGHT CHECKS', colors.bright);
  log('================================', colors.blue);

  // Check Node.js version
  try {
    const nodeVersion = runCommand('node --version');
    const version = nodeVersion.trim().replace('v', '');
    const majorVersion = parseInt(version.split('.')[0]);
    check(majorVersion >= 18, `Node.js v${version} detected (>=18 required)`, 'preflight');
  } catch (error) {
    check(false, 'Node.js not found or incompatible', 'preflight');
  }

  // Check if we're in the right directory
  const isInProject = fs.existsSync('ui-tests') && fs.existsSync('api-tests');
  check(isInProject, 'Project structure detected (ui-tests, api-tests)', 'preflight');

  // Check UI tests dependencies
  if (fs.existsSync('ui-tests/package.json')) {
    try {
      const packageJson = JSON.parse(fs.readFileSync('ui-tests/package.json', 'utf8'));
      check(packageJson.dependencies && Object.keys(packageJson.dependencies).length > 0, 
            'UI dependencies configured', 'preflight');
    } catch (error) {
      check(false, 'UI package.json invalid or missing', 'preflight');
    }
  }

  // Check API tests dependencies
  if (fs.existsSync('api-tests/pom.xml')) {
    check(true, 'API Maven configuration found', 'preflight');
  }

  // Check configuration files
  check(fs.existsSync('ui-tests/playwright.config.ts'), 'Playwright config present', 'preflight');
  check(fs.existsSync('ui-tests/.env.sample'), 'Environment sample file present', 'preflight');
  check(fs.existsSync('api-tests/.env.sample'), 'API environment sample present', 'preflight');

  // Check for sensitive data
  const sensitiveFiles = ['.env', 'credentials.json', 'secrets.json'];
  let hasSensitiveData = false;
  sensitiveFiles.forEach(file => {
    if (fs.existsSync(`ui-tests/${file}`) || fs.existsSync(`api-tests/${file}`)) {
      hasSensitiveData = true;
    }
  });
  check(!hasSensitiveData, 'No sensitive data files committed', 'preflight');

  return results.preflight;
}

async function validateTests() {
  log('\n🧪 TEST EXECUTION VALIDATION', colors.bright);
  log('================================', colors.blue);

  // UI Tests Validation
  log('\n📱 UI Tests:', colors.cyan);
  if (fs.existsSync('ui-tests')) {
    try {
      process.chdir('ui-tests');
      
      // Install dependencies
      log('  Installing UI dependencies...', colors.yellow);
      const installResult = runCommand('npm ci');
      check(!installResult.error, 'UI dependencies installed successfully', 'tests');

      // Run UI tests
      log('  Running UI tests...', colors.yellow);
      const testResult = runCommand('npx playwright test --reporter=json');
      
      if (!testResult.error) {
        try {
          const testData = JSON.parse(testResult);
          const totalTests = testData.stats.total;
          const passedTests = testData.stats.passed;
          const failedTests = testData.stats.failed;
          
          check(passedTests > 0, `UI tests executed: ${passedTests}/${totalTests} passed`, 'tests');
          check(failedTests === 0, `No UI test failures: ${failedTests} failed`, 'tests');
        } catch (parseError) {
          check(false, 'UI test results could not be parsed', 'tests');
        }
      } else {
        check(false, 'UI tests failed to execute', 'tests');
      }
      
      process.chdir('..');
    } catch (error) {
      check(false, `UI test execution error: ${error.message}`, 'tests');
    }
  } else {
    check(false, 'UI tests directory not found', 'tests');
  }

  // API Tests Validation
  log('\n🔌 API Tests:', colors.cyan);
  if (fs.existsSync('api-tests')) {
    try {
      process.chdir('api-tests');
      
      // Run API tests
      log('  Running API tests...', colors.yellow);
      const testResult = runCommand('mvn test -Dtest=InventoryTestRunner');
      
      if (!testResult.error) {
        check(true, 'API tests executed successfully', 'tests');
      } else {
        check(false, 'API tests failed to execute', 'tests');
      }
      
      process.chdir('..');
    } catch (error) {
      check(false, `API test execution error: ${error.message}`, 'tests');
    }
  } else {
    check(false, 'API tests directory not found', 'tests');
  }

  return results.tests;
}

async function validateCodeQuality() {
  log('\n📊 CODE QUALITY CHECKS', colors.bright);
  log('================================', colors.blue);

  // Check for console.log statements
  const findConsoleLogs = (dir) => {
    const files = fs.readdirSync(dir, { withFileTypes: true });
    let consoleLogs = [];
    
    files.forEach(file => {
      const fullPath = path.join(dir, file.name);
      if (file.isDirectory() && !file.name.startsWith('.') && file.name !== 'node_modules') {
        consoleLogs = consoleLogs.concat(findConsoleLogs(fullPath));
      } else if (file.name.endsWith('.ts') || file.name.endsWith('.js')) {
        try {
          const content = fs.readFileSync(fullPath, 'utf8');
          const lines = content.split('\n');
          lines.forEach((line, index) => {
            if (line.includes('console.log') && !line.trim().startsWith('//')) {
              consoleLogs.push(`${fullPath}:${index + 1}`);
            }
          });
        } catch (error) {
          // Skip files that can't be read
        }
      }
    });
    
    return consoleLogs;
  };

  const consoleLogs = findConsoleLogs('ui-tests');
  check(consoleLogs.length === 0, `No console.log statements found (${consoleLogs.length} found)`, 'quality');

  // Check for hardcoded credentials
  const findHardcodedCreds = (dir) => {
    const files = fs.readdirSync(dir, { withFileTypes: true });
    let hardcodedCreds = [];
    
    files.forEach(file => {
      const fullPath = path.join(dir, file.name);
      if (file.isDirectory() && !file.name.startsWith('.') && file.name !== 'node_modules') {
        hardcodedCreds = hardcodedCreds.concat(findHardcodedCreds(fullPath));
      } else if (file.name.endsWith('.ts') || file.name.endsWith('.js')) {
        try {
          const content = fs.readFileSync(fullPath, 'utf8');
          const credPatterns = [
            /password\s*=\s*['"][^'"]+['"]/i,
            /api[_-]?key\s*=\s*['"][^'"]+['"]/i,
            /token\s*=\s*['"][^'"]+['"]/i
          ];
          
          credPatterns.forEach(pattern => {
            if (pattern.test(content)) {
              hardcodedCreds.push(fullPath);
            }
          });
        } catch (error) {
          // Skip files that can't be read
        }
      }
    });
    
    return hardcodedCreds;
  };

  const hardcodedCreds = findHardcodedCreds('ui-tests');
  check(hardcodedCreds.length === 0, `No hardcoded credentials found (${hardcodedCreds.length} found)`, 'quality');

  // Check for proper error handling
  const findErrorHandling = (dir) => {
    const files = fs.readdirSync(dir, { withFileTypes: true });
    let errorHandling = { good: 0, needsImprovement: 0 };
    
    files.forEach(file => {
      const fullPath = path.join(dir, file.name);
      if (file.isDirectory() && !file.name.startsWith('.') && file.name !== 'node_modules') {
        const subResult = findErrorHandling(fullPath);
        errorHandling.good += subResult.good;
        errorHandling.needsImprovement += subResult.needsImprovement;
      } else if (file.name.endsWith('.ts') || file.name.endsWith('.js')) {
        try {
          const content = fs.readFileSync(fullPath, 'utf8');
          if (content.includes('try') && content.includes('catch')) {
            errorHandling.good++;
          } else if (content.includes('await') || content.includes('Promise')) {
            errorHandling.needsImprovement++;
          }
        } catch (error) {
          // Skip files that can't be read
        }
      }
    });
    
    return errorHandling;
  };

  const errorHandling = findErrorHandling('ui-tests');
  check(errorHandling.needsImprovement === 0, 'Proper error handling implemented', 'quality');

  return results.quality;
}

async function validateReports() {
  log('\n📁 REPORTS & ARTIFACTS', colors.bright);
  log('================================', colors.blue);

  // Check if reports directory exists
  check(fs.existsSync('ui-tests/playwright-report'), 'Playwright report directory exists', 'reports');
  check(fs.existsSync('api-tests/target/surefire-reports'), 'API test reports directory exists', 'reports');

  // Check for HTML reports
  if (fs.existsSync('ui-tests/playwright-report')) {
    const reportFiles = fs.readdirSync('ui-tests/playwright-report');
    check(reportFiles.length > 0, 'Test reports generated', 'reports');
  }

  return results.reports;
}

async function generateSummary() {
  log('\n📋 VALIDATION SUMMARY', colors.bright);
  log('================================', colors.blue);

  const totalPassed = Object.values(results).reduce((sum, category) => sum + category.passed, 0);
  const totalFailed = Object.values(results).reduce((sum, category) => sum + category.failed, 0);
  const totalChecks = totalPassed + totalFailed;
  const successRate = ((totalPassed / totalChecks) * 100).toFixed(1);

  log(`\n📊 OVERALL RESULTS:`, colors.bright);
  log(`   Total Checks: ${totalChecks}`, colors.blue);
  log(`   Passed: ${totalPassed}`, colors.green);
  log(`   Failed: ${totalFailed}`, colors.red);
  log(`   Success Rate: ${successRate}%`, colors.yellow);

  // Determine delivery readiness
  let deliveryStatus;
  let statusColor;
  
  if (totalFailed === 0) {
    deliveryStatus = '✅ READY FOR DELIVERY';
    statusColor = colors.green;
  } else if (totalFailed <= 2) {
    deliveryStatus = '⚠️ MINOR FIXES NEEDED';
    statusColor = colors.yellow;
  } else {
    deliveryStatus = '❌ MAJOR ISSUES DETECTED';
    statusColor = colors.red;
  }

  log(`\n🚦 FINAL STATUS: ${deliveryStatus}`, statusColor);

  // List issues if any
  if (totalFailed > 0) {
    log('\n⚠️ ISSUES TO ADDRESS:', colors.yellow);
    Object.entries(results).forEach(([category, result]) => {
      if (result.issues.length > 0) {
        log(`\n${category.toUpperCase()}:`, colors.cyan);
        result.issues.forEach(issue => {
          log(`  - ${issue}`, colors.red);
        });
      }
    });
  }

  // Exit with appropriate code
  process.exit(totalFailed === 0 ? 0 : 1);
}

// Main execution
async function main() {
  log('🔍 PROJECT VALIDATION REPORT', colors.bright);
  log('================================', colors.blue);
  log('Principal QA Engineer - Delivery Readiness Audit', colors.cyan);
  log('');

  try {
    await validatePreflight();
    await validateTests();
    await validateCodeQuality();
    await validateReports();
    await generateSummary();
  } catch (error) {
    log(`\n❌ Validation failed with error: ${error.message}`, colors.red);
    process.exit(1);
  }
}

// Run the validation
main();
