const mongoose = require('mongoose');
const { MarketplaceCategory, MarketplaceItem } = require('../models/marketplaceModel');

const marketplaceSeeds = [
  {
    name: 'Avatars',
    description: 'Custom profile pictures and avatars',
    icon: 'person',
    order: 1
  },
  {
    name: 'Themes',
    description: 'App themes and color schemes',
    icon: 'palette',
    order: 2
  },
  {
    name: 'Badges',
    description: 'Special achievement badges',
    icon: 'military_tech',
    order: 3
  },
  {
    name: 'Power-ups',
    description: 'Game enhancements and boosts',
    icon: 'flash',
    order: 4
  }
];

const marketplaceItems = [
  {
    name: 'Premium Avatar Pack',
    description: 'Unlock 10 exclusive avatar options',
    price: 500,
    image: 'https://placehold.co/200x200?text=Avatar+Pack',
    featured: true,
    available: true
  },
  {
    name: 'Dark Theme',
    description: 'Elegant dark theme for the app',
    price: 200,
    image: 'https://placehold.co/200x200?text=Dark+Theme',
    featured: true,
    available: true
  },
  {
    name: 'XP Booster',
    description: 'Double XP for 24 hours',
    price: 300,
    image: 'https://placehold.co/200x200?text=XP+Booster',
    featured: false,
    available: true,
    expiryDays: 1
  },
  {
    name: 'Golden Badge Frame',
    description: 'Special golden frame for your badges',
    price: 400,
    image: 'https://placehold.co/200x200?text=Golden+Badge',
    featured: false,
    available: true,
    permanent: true
  }
];

const seedMarketplace = async () => {
  try {
    console.log('🌱 Seeding marketplace data...');

    // Clear existing data
    await MarketplaceCategory.deleteMany({});
    await MarketplaceItem.deleteMany({});

    // Insert categories
    const categories = await MarketplaceCategory.insertMany(marketplaceSeeds);
    console.log(`✅ Created ${categories.length} marketplace categories`);

    // Update items with category references
    const avatarCategory = categories.find(cat => cat.name === 'Avatars');
    const themeCategory = categories.find(cat => cat.name === 'Themes');
    const badgeCategory = categories.find(cat => cat.name === 'Badges');
    const powerUpCategory = categories.find(cat => cat.name === 'Power-ups');

    marketplaceItems[0].categoryId = avatarCategory._id; // Premium Avatar Pack
    marketplaceItems[1].categoryId = themeCategory._id; // Dark Theme
    marketplaceItems[2].categoryId = powerUpCategory._id; // XP Booster
    marketplaceItems[3].categoryId = badgeCategory._id; // Golden Badge Frame

    // Insert items
    const items = await MarketplaceItem.insertMany(marketplaceItems);
    console.log(`✅ Created ${items.length} marketplace items`);

    console.log('🎉 Marketplace seeding completed successfully!');
  } catch (error) {
    console.error('❌ Error seeding marketplace:', error);
    throw error;
  }
};

module.exports = { seedMarketplace };

