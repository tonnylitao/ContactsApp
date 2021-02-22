import React from 'react';
import {StyleSheet, ScrollView, View, Image, Text} from 'react-native';
import {StackScreenProps} from '@react-navigation/stack';
import {Contact} from '@model/Contact';
//@ts-ignore
import {Flag} from 'react-native-svg-flagkit';

type ProfileStackParamList = {
  Profile: Contact;
};

type Props = StackScreenProps<ProfileStackParamList, 'Profile'>;

const Screen = ({route}: Props) => {
  const contact = route.params;

  return (
    <ScrollView>
      <View style={styles.header}>
        <View style={styles.avatarContainer}>
          <Image
            style={styles.avatar}
            source={{uri: contact.picture.thumbnail}}
          />
          <Image
            style={styles.gender}
            source={
              contact.gender === 'male'
                ? require('../img/ic_male.png')
                : require('../img/ic_female.png')
            }
          />
        </View>

        <Text style={styles.name}>
          <Text style={styles.userTitle}>{contact.name.title} </Text>
          {contact.name.first} {contact.name.last}
        </Text>
      </View>

      <View style={styles.cell}>
        <Text style={styles.cellTitle}>Date of Birth</Text>
        <Text>{contact.dobString}</Text>
      </View>
      <View style={styles.cell}>
        <Text style={styles.cellTitle}>Email</Text>
        <Text>{contact.email}</Text>
      </View>
      <View style={styles.cell}>
        <Text style={styles.cellTitle}>Phone</Text>
        <Text>{contact.phone}</Text>
      </View>
      <View style={styles.cell}>
        <Text style={styles.cellTitle}>Cell</Text>
        <Text>{contact.cell}</Text>
      </View>
      <View style={styles.cell}>
        <Text style={styles.cellTitle}>Nationality</Text>
        <View style={styles.flagCnt}>
          <Text>{contact.nat}</Text>
          <Flag id={contact.nat} width={30} height={20} />
        </View>
      </View>
      <View style={styles.cell}>
        <Text style={styles.cellTitle}>Address</Text>
        <Text>
          {contact.location.street.number} {contact.location.street.name}{' '}
          {contact.location.state} {contact.location.country}{' '}
          {contact.location.postcode}
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  header: {
    height: 200,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    borderBottomColor: '#ccc',
    borderStyle: 'solid',
    borderBottomWidth: 0.5,
  },

  avatarContainer: {
    position: 'relative',
    width: 100,
    height: 100,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
  },

  name: {
    fontSize: 18,
    marginBottom: 5,
    marginTop: 20,
  },
  userTitle: {
    fontSize: 16,
    color: 'rgb(105, 105, 105)',
  },
  gender: {
    width: 30,
    height: 30,
    borderRadius: 15,
    position: 'absolute',
    right: -5,
    bottom: 0,
  },

  cell: {
    marginLeft: 20,
    marginTop: 20,
    paddingRight: 20,
    paddingBottom: 20,
    borderBottomColor: '#ccc',
    borderStyle: 'solid',
    borderBottomWidth: 0.5,
  },

  cellTitle: {
    fontSize: 18,
  },

  flagCnt: {
    marginTop: 10,
    flexDirection: 'row',
    alignItems: 'center',
  },
});

export default Screen;
