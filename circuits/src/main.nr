// Age verification circuit in Noir
// Proves that user_age >= min_age without revealing the actual age

fn main(
    user_age: Field,      // Private input: user's actual age
    min_age: pub Field,   // Public input: minimum required age
) -> pub Field {          // Public output: 1 if valid, 0 if invalid
    
    // Convert Fields to u32 for comparison
    let user_age_u32 = user_age as u32;
    let min_age_u32 = min_age as u32;
    
    // Check if user_age >= min_age
    let is_valid = if user_age_u32 >= min_age_u32 { 1 } else { 0 };
    
    // Return the result
    is_valid
}
