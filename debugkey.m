// Debug tool to export and inspect SSH keys from Blink keychain
// Compile: clang -framework Foundation -framework Security -o debugkey debugkey.m

#import <Foundation/Foundation.h>
#import <Security/Security.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            printf("Usage: %s <key_name>\n", argv[0]);
            return 1;
        }
        
        NSString *keyName = [NSString stringWithUTF8String:argv[1]];
        NSString *service = @"sh.blink.pkcard";
        
        // Query for the private key
        NSString *privateKeyRef = [NSString stringWithFormat:@"%@.privateKey.openssh", keyName];
        
        NSDictionary *query = @{
            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
            (__bridge id)kSecAttrService: service,
            (__bridge id)kSecAttrAccount: privateKeyRef,
            (__bridge id)kSecReturnData: @YES,
            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
        };
        
        CFTypeRef result = NULL;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        
        if (status == errSecSuccess) {
            NSData *keyData = (__bridge_transfer NSData *)result;
            NSString *privateKey = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
            
            printf("=== Private Key for '%s' ===\n", [keyName UTF8String]);
            printf("%s\n", [privateKey UTF8String]);
            printf("=== End Private Key ===\n");
            
            // Save to file
            NSString *filename = [NSString stringWithFormat:@"%@_private.key", keyName];
            [privateKey writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:nil];
            printf("Private key saved to: %s\n", [filename UTF8String]);
        } else {
            printf("Failed to retrieve key '%s' from keychain. Error: %d\n", [keyName UTF8String], (int)status);
            
            // Try alternate key reference format
            NSString *altPrivateKeyRef = [NSString stringWithFormat:@"%@.pem", keyName];
            query = @{
                (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                (__bridge id)kSecAttrService: service,
                (__bridge id)kSecAttrAccount: altPrivateKeyRef,
                (__bridge id)kSecReturnData: @YES,
                (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
            };
            
            status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
            if (status == errSecSuccess) {
                NSData *keyData = (__bridge_transfer NSData *)result;
                NSString *privateKey = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
                
                printf("=== Private Key (alternate format) for '%s' ===\n", [keyName UTF8String]);
                printf("%s\n", [privateKey UTF8String]);
                printf("=== End Private Key ===\n");
                
                // Save to file
                NSString *filename = [NSString stringWithFormat:@"%@_private.key", keyName];
                [privateKey writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:nil];
                printf("Private key saved to: %s\n", [filename UTF8String]);
            }
        }
        
        // List all keys in the keychain for this service
        printf("\n=== All keys in Blink keychain ===\n");
        NSDictionary *listQuery = @{
            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
            (__bridge id)kSecAttrService: service,
            (__bridge id)kSecReturnAttributes: @YES,
            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll
        };
        
        CFTypeRef items = NULL;
        status = SecItemCopyMatching((__bridge CFDictionaryRef)listQuery, &items);
        
        if (status == errSecSuccess) {
            NSArray *keychainItems = (__bridge_transfer NSArray *)items;
            for (NSDictionary *item in keychainItems) {
                NSString *account = item[(__bridge id)kSecAttrAccount];
                printf("- %s\n", [account UTF8String]);
            }
        }
    }
    return 0;
}