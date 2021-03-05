import React from 'react';
import {StyleSheet, ScrollView, View, Image, Text} from 'react-native';
import {StackScreenProps} from '@react-navigation/stack';
import {Contact, Location} from '@model/Contact';
//@ts-ignore
import {Flag} from 'react-native-svg-flagkit';
import {style as AppStyle, theme} from '../style';

type ProfileStackParamList = {
  Profile: Contact;
};

type Props = StackScreenProps<ProfileStackParamList, 'Profile'>;

const Cell = ({
  title,
  value,
}: {
  title: string;
  value: string | (() => JSX.Element);
}) => (
  <View style={AppStyle.cell}>
    <Text style={styles.cellTitle}>{title}</Text>
    {typeof value === 'string' ? (
      <Text style={styles.cellValue}>{value}</Text>
    ) : (
      value()
    )}
  </View>
);

function fullAddress({street, state, country, postcode}: Location) {
  return `${street.number} ${street.name} ${state} ${country} ${postcode}`;
}

const Screen = ({route}: Props) => {
  const contact = route.params;

  return (
    <ScrollView>
      <View style={styles.header}>
        <View style={styles.avatarCnt}>
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
          <Text style={styles.nameTitle}>{contact.name.title} </Text>
          {contact.name.first} {contact.name.last}
        </Text>
      </View>

      <Cell title="Date of Birth" value={contact.dobString} />
      <Cell title="Email" value={contact.email} />
      <Cell title="Phone" value={contact.phone} />
      <Cell title="Cell" value={contact.cell} />

      <Cell
        title="Nationality"
        value={() => (
          <View style={styles.flagCnt}>
            <Text>{contact.nat} </Text>
            <Flag id={contact.nat} width={30} height={20} />
          </View>
        )}
      />
      <Cell title="Address" value={fullAddress(contact.location)} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  header: {
    ...AppStyle.center,
    height: 200,
    borderBottomColor: '#ccc',
    borderStyle: 'solid',
    borderBottomWidth: 0.5,
  },

  avatarCnt: {
    width: 100,
  },
  avatar: {
    width: '100%',
    aspectRatio: 1,
    borderRadius: 50,
  },
  gender: {
    width: 30,
    height: 30,
    borderRadius: 15,
    position: 'absolute',
    right: -5,
    bottom: 0,
  },

  name: {
    fontSize: theme.fontSize.l,
    marginBottom: 5,
    marginTop: 20,
  },
  nameTitle: {
    fontSize: theme.fontSize.m,
    color: theme.color.lightText,
  },

  cellTitle: {
    fontSize: theme.fontSize.m,
    color: theme.color.lightText,
    marginBottom: 5,
  },
  cellValue: {
    fontSize: theme.fontSize.l,
  },

  flagCnt: {
    marginTop: 10,
    flexDirection: 'row',
    alignItems: 'center',
  },
});

export default Screen;
